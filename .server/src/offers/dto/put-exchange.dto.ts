import { ApiProperty } from '@nestjs/swagger';

class IceCandidate {
  @ApiProperty()
  media: string;

  @ApiProperty()
  index: number;

  @ApiProperty()
  name: string;
}

class SessionDescription {
  @ApiProperty()
  type: string;

  @ApiProperty()
  sdp: string;
}

class OfferExchange {
  @ApiProperty({ type: [IceCandidate] })
  iceCandidates: IceCandidate[];

  @ApiProperty({ type: SessionDescription })
  sessionDescription: SessionDescription;
}

export class PutExchangeDto {
  @ApiProperty({ type: OfferExchange })
  exchange: OfferExchange;
}
