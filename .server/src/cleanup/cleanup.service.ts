import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { OfferRequest } from '../entities/offer-request.entity';
import { Offer } from '../entities/offer.entity';
import { Repository, Raw } from 'typeorm';

@Injectable()
export class CleanupService {
  private readonly logger = new Logger(CleanupService.name);

  constructor(
    @InjectRepository(OfferRequest)
    private offerRequestRepository: Repository<OfferRequest>,
    @InjectRepository(Offer)
    private offerRepository: Repository<Offer>,
  ) {}

  async removeOldEntries(): Promise<{
    requestsDeleted: number;
    offersDeleted: number;
  }> {
    // Step 1: Delete old OfferRequests using database time
    const deleteRequestsResult = await this.offerRequestRepository.delete({
      timestamp: Raw((alias) => `${alias} < NOW() - INTERVAL '10 minutes'`),
    });
    const requestsDeleted = deleteRequestsResult.affected || 0;

    // Step 2: Delete old Offers with no remaining associated OfferRequests using database time
    const oldOffers = await this.offerRepository.find({
      where: {
        timestamp: Raw((alias) => `${alias} < NOW() - INTERVAL '10 minutes'`),
      },
      relations: ['requests'],
    });

    // Filter out offers that still have active requests
    const offersToDelete = oldOffers.filter(
      (offer) => offer.requests.length === 0,
    );
    const offersDeleted = offersToDelete.length;

    // Delete the filtered offers
    if (offersDeleted > 0) {
      await this.offerRepository.remove(offersToDelete);
    }

    this.logger.log(
      `Deleted ${requestsDeleted} old OfferRequest(s) and ${offersDeleted} old Offer(s)`,
    );
    return { requestsDeleted, offersDeleted };
  }
}
