import { ApiProperty } from '@nestjs/swagger';

export class Offer {
  @ApiProperty()
  type: string;

  @ApiProperty()
  sdp: string;
}

export class Ice {
  @ApiProperty()
  media: string;

  @ApiProperty()
  index: number;

  @ApiProperty()
  name: string;
}

export class LobbyRequest {
  @ApiProperty()
  offer: Offer;

  @ApiProperty()
  ice: Ice;

  @ApiProperty()
  is_public: 0 | 1;

  @ApiProperty()
  project: string;

  @ApiProperty()
  name: string;
}

export class ClientRequest {
  @ApiProperty()
  offer: Offer;

  @ApiProperty()
  ice: Ice;

  @ApiProperty()
  project: string;

  @ApiProperty()
  name: string;
}
