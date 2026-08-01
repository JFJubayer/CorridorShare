import { spawnSync } from "node:child_process";
import { readFileSync } from "node:fs";

const policyUrl = new URL("../security/audit-exceptions.json", import.meta.url);
const policy = JSON.parse(readFileSync(policyUrl, "utf8"));

if (policy.schemaVersion !== 1 || !Array.isArray(policy.exceptions)) {
  throw new Error("Unsupported production audit exception policy");
}

const npmCommand = process.platform === "win32" ? "npm.cmd" : "npm";
const audit = spawnSync(npmCommand, ["audit", "--omit=dev", "--json"], {
  cwd: new URL("..", import.meta.url),
  encoding: "utf8",
});

if (audit.error) {
  throw audit.error;
}

let report;
try {
  report = JSON.parse(audit.stdout);
} catch {
  process.stderr.write(audit.stderr);
  throw new Error("npm audit did not return valid JSON");
}

if (report.error) {
  throw new Error(`npm audit failed: ${report.error.summary ?? report.error.code}`);
}

const vulnerabilities = report.vulnerabilities ?? {};
if (Object.keys(vulnerabilities).length === 0) {
  console.log("Production dependency audit passed with no vulnerabilities.");
  process.exit(0);
}

const exceptions = new Map();
for (const entry of policy.exceptions) {
  const advisory = entry.advisory.toUpperCase();
  const key = `${entry.package}:${advisory}`;
  if (exceptions.has(key)) {
    throw new Error(`Duplicate audit exception: ${key}`);
  }
  if (!/^GHSA-[a-z0-9-]+$/i.test(entry.advisory)) {
    throw new Error(`Invalid advisory ID in audit policy: ${entry.advisory}`);
  }
  if (!/^\d{4}-\d{2}-\d{2}$/.test(entry.expires)) {
    throw new Error(`Invalid expiry date for ${key}`);
  }
  exceptions.set(key, { ...entry, advisory });
}

const findings = [];
const accepted = new Set();
const checkedPackages = new Map();

function checkPackage(packageName, visiting = new Set()) {
  if (checkedPackages.has(packageName)) {
    return checkedPackages.get(packageName);
  }
  if (visiting.has(packageName)) {
    findings.push(`Cyclic npm audit dependency reference at ${packageName}`);
    return false;
  }

  const vulnerability = vulnerabilities[packageName];
  if (!vulnerability) {
    findings.push(`Audit references missing vulnerability details for ${packageName}`);
    return false;
  }

  const nextVisiting = new Set(visiting).add(packageName);
  let allowed = vulnerability.via.length > 0;

  for (const via of vulnerability.via) {
    if (typeof via === "string") {
      allowed = checkPackage(via, nextVisiting) && allowed;
      continue;
    }

    const advisory = via.url?.match(/GHSA-[a-z0-9-]+/i)?.[0]?.toUpperCase();
    if (!advisory) {
      findings.push(`${packageName} has an advisory without a GHSA ID: ${via.title}`);
      allowed = false;
      continue;
    }

    const key = `${packageName}:${advisory}`;
    const exception = exceptions.get(key);
    if (!exception) {
      findings.push(`Unexpected production advisory ${advisory} in ${packageName}`);
      allowed = false;
      continue;
    }

    const expiresAfter = Date.parse(`${exception.expires}T23:59:59.999Z`);
    if (!Number.isFinite(expiresAfter) || Date.now() > expiresAfter) {
      findings.push(`Expired production audit exception ${key} (${exception.expires})`);
      allowed = false;
      continue;
    }

    accepted.add(key);
  }

  checkedPackages.set(packageName, allowed);
  return allowed;
}

for (const packageName of Object.keys(vulnerabilities)) {
  checkPackage(packageName);
}

if (findings.length > 0 || [...checkedPackages.values()].some((allowed) => !allowed)) {
  console.error("Production dependency audit failed:");
  for (const finding of new Set(findings)) {
    console.error(`- ${finding}`);
  }
  process.exit(1);
}

console.warn("Production audit passed with temporary exceptions:");
for (const key of [...accepted].sort()) {
  const exception = exceptions.get(key);
  console.warn(`- ${key} (expires ${exception.expires})`);
}
