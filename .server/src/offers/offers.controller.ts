import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Query,
  Put,
  Res,
  HttpStatus,
} from '@nestjs/common';
import { OffersService } from './offers.service';
import { Response } from 'express';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiParam,
  ApiBody,
} from '@nestjs/swagger';
import { CreateOfferDto } from './dto/create-offer.dto';
import { PutExchangeDto } from './dto/put-exchange.dto';
import { CleanupService } from '../cleanup/cleanup.service';

@ApiTags('offers')
@Controller('offers')
export class OffersController {
  constructor(
    private offersService: OffersService,
    private readonly cleanupService: CleanupService,
  ) {}

  // 1. Register existence of an offer
  @ApiOperation({ summary: 'Register a new offer' })
  @ApiResponse({
    status: HttpStatus.CREATED,
    description: 'Offer created',
    schema: { example: { uuid: 'string' } },
  })
  @Post()
  async createOffer(
    @Body() createOfferDto: CreateOfferDto,
  ): Promise<{ uuid: string }> {
    const offer = await this.offersService.createOffer(
      createOfferDto.name,
      createOfferDto.isPublic,
    );
    return { uuid: offer.uuid };
  }

  // 2. Get all public offers
  @ApiOperation({ summary: 'Get all public offers' })
  @ApiResponse({ status: HttpStatus.OK, description: 'List of public offers' })
  @Get()
  async getPublicOffers() {
    await this.cleanupService.removeOldEntries();

    return await this.offersService.getPublicOffers();
  }

  // 2. Get offer by UUID
  @ApiOperation({ summary: 'Get offer by UUID' })
  @ApiParam({ name: 'uuid', required: true })
  @ApiResponse({ status: HttpStatus.OK, description: 'Offer details' })
  @Get(':uuid')
  async getOffer(@Param('uuid') uuid: string) {
    return await this.offersService.getOffer(uuid);
  }

  // 3. Add an OfferRequest to an offer
  @ApiOperation({ summary: 'Add an OfferRequest to an offer' })
  @ApiParam({ name: 'uuid', description: 'Offer UUID' })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Waits for exchange.server to be set',
  })
  @Post(':uuid/requests')
  async createOfferRequest(
    @Param('uuid') offerUuid: string,
    @Res() res: Response,
  ) {
    const offerRequest = await this.offersService.createOfferRequest(offerUuid);

    // Keep the connection open
    const interval = setInterval(async () => {
      const updatedRequest = await this.offersService.getOfferRequest(
        offerRequest.uuid,
      );
      if (updatedRequest.exchange && updatedRequest.exchange.server) {
        clearInterval(interval);
        res.json({
          ...updatedRequest.exchange.server,
          uuid: offerRequest.uuid,
        });
      }
    }, 1000);

    res.on('close', () => {
      clearInterval(interval);
    });
  }

  // 4. Get unresolved OfferRequests for an offer
  @ApiOperation({ summary: 'Get unresolved OfferRequests for an offer' })
  @ApiParam({ name: 'uuid', description: 'Offer UUID' })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'List of unresolved OfferRequests',
  })
  @Get(':uuid/requests')
  async getOfferRequests(@Param('uuid') offerUuid: string) {
    return await this.offersService.getUnresolvedOfferRequest(offerUuid);
  }

  // 5. Update OfferRequest's exchange.server
  @ApiOperation({
    summary:
      "Update OfferRequest's exchange.server and wait for exchange.client",
  })
  @ApiParam({ name: 'requestUuid', description: 'Request UUID' })
  @ApiBody({ type: PutExchangeDto })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Waits for exchange.client to be set',
  })
  @Put('requests/:requestUuid/exchange/server')
  async putExchangeServer(
    @Param('requestUuid') requestUuid: string,
    @Body() exchangeServerDto: PutExchangeDto,
    @Res() res: Response,
  ) {
    await this.offersService.updateExchangeServer(
      requestUuid,
      exchangeServerDto.exchange,
    );

    // Keep the connection open
    const interval = setInterval(async () => {
      const updatedRequest =
        await this.offersService.getOfferRequest(requestUuid);
      if (updatedRequest.exchange && updatedRequest.exchange.client) {
        clearInterval(interval);
        res.json(updatedRequest.exchange.client);
      }
    }, 1000);

    res.on('close', () => {
      clearInterval(interval);
    });
  }

  // 7. Update OfferRequest's exchange.client
  @ApiOperation({ summary: "Update OfferRequest's exchange.client" })
  @ApiParam({ name: 'requestUuid', description: 'Request UUID' })
  @ApiBody({ type: PutExchangeDto })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Client exchange updated',
  })
  @Put('requests/:requestUuid/exchange/client')
  async putExchangeClient(
    @Param('requestUuid') requestUuid: string,
    @Body() exchangeClientDto: PutExchangeDto,
  ) {
    await this.offersService.updateExchangeClient(
      requestUuid,
      exchangeClientDto.exchange,
    );
    return { success: true };
  }
}
