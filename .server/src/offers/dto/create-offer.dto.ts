import { ApiProperty } from '@nestjs/swagger';

export class CreateOfferDto {
  @ApiProperty({ example: 'Offer Name' })
  name: string;

  @ApiProperty({ example: true })
  isPublic: boolean;
}
