import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { OffersController } from './offers.controller';
import { OffersService } from './offers.service';
import { Offer } from '../entities/offer.entity';
import { OfferRequest } from '../entities/offer-request.entity';
import { CleanupService } from 'src/cleanup/cleanup.service';

@Module({
  imports: [TypeOrmModule.forFeature([Offer, OfferRequest])],
  controllers: [OffersController],
  providers: [OffersService, CleanupService],
})
export class OffersModule {}
