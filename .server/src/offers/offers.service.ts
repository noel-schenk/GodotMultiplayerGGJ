import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Offer } from '../entities/offer.entity';
import { OfferRequest } from '../entities/offer-request.entity';
import { Repository } from 'typeorm';

@Injectable()
export class OffersService {
  constructor(
    @InjectRepository(Offer)
    private offerRepository: Repository<Offer>,
    @InjectRepository(OfferRequest)
    private offerRequestRepository: Repository<OfferRequest>,
  ) {}

  async createOffer(name: string, isPublic: boolean): Promise<Offer> {
    const offer = this.offerRepository.create({ name, isPublic });
    return await this.offerRepository.save(offer);
  }

  async getPublicOffers(): Promise<Offer[]> {
    return await this.offerRepository.find({ where: { isPublic: true } });
  }

  async getOffer(uuid: string): Promise<Offer> {
    const offer = await this.offerRepository.findOne({
      where: { uuid },
      relations: ['requests'],
    });
    if (!offer) {
      throw new NotFoundException('Offer not found');
    }
    return offer;
  }

  async createOfferRequest(offerUuid: string): Promise<OfferRequest> {
    const offer = await this.getOffer(offerUuid);
    const offerRequest = this.offerRequestRepository.create({
      offer,
      exchange: {},
    });
    return await this.offerRequestRepository.save(offerRequest);
  }

  async getOfferRequest(requestUuid: string): Promise<OfferRequest> {
    const request = await this.offerRequestRepository.findOne({
      where: { uuid: requestUuid },
    });
    if (!request) {
      throw new NotFoundException('OfferRequest not found');
    }
    return request;
  }

  async getUnresolvedOfferRequest(offerUuid: string): Promise<OfferRequest> {
    const offer = await this.getOffer(offerUuid);
    return offer.requests
      .filter((request) => !request.isResolved)
      .sort((a, b) => a.timestamp.getTime() - b.timestamp.getTime())[0];
  }

  async updateExchangeServer(
    requestUuid: string,
    exchangeServer: any,
  ): Promise<void> {
    const request = await this.getOfferRequest(requestUuid);
    if (!request.exchange) {
      request.exchange = {};
    }
    request.exchange.server = exchangeServer;
    await this.offerRequestRepository.save(request);
  }

  async updateExchangeClient(
    requestUuid: string,
    exchangeClient: any,
  ): Promise<void> {
    const request = await this.getOfferRequest(requestUuid);
    if (!request.exchange) {
      request.exchange = {};
    }
    request.exchange.client = exchangeClient;
    request.isResolved = true;
    await this.offerRequestRepository.save(request);
  }
}
