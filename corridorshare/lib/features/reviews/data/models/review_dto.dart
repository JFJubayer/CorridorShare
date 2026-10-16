import 'package:corridorshare/features/reviews/domain/entities/review.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'review_dto.freezed.dart';
part 'review_dto.g.dart';

@freezed
abstract class ReviewDto with _$ReviewDto {
  const factory ReviewDto({
    required String id,
    required String deliveryId,
    required String reviewerId,
    required String reviewerName,
    required String targetUserId,
    required String targetUserName,
    required int rating,
    required String comment,
    required String createdAt,
  }) = _ReviewDto;

  factory ReviewDto.fromJson(Map<String, dynamic> json) =>
      _$ReviewDtoFromJson(json);

  factory ReviewDto.fromDomain(Review domain) => ReviewDto(
        id: domain.id,
        deliveryId: domain.deliveryId,
        reviewerId: domain.reviewerId,
        reviewerName: domain.reviewerName,
        targetUserId: domain.targetUserId,
        targetUserName: domain.targetUserName,
        rating: domain.rating,
        comment: domain.comment,
        createdAt: domain.createdAt.toIso8601String(),
      );
}

extension ReviewDtoX on ReviewDto {
  Review toDomain() => Review(
        id: id,
        deliveryId: deliveryId,
        reviewerId: reviewerId,
        reviewerName: reviewerName,
        targetUserId: targetUserId,
        targetUserName: targetUserName,
        rating: rating,
        comment: comment,
        createdAt: DateTime.parse(createdAt),
      );
}
