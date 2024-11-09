import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  OneToMany,
  CreateDateColumn,
} from 'typeorm';
import { OfferRequest } from './offer-request.entity';

@Entity('offers')
export class Offer {
  @PrimaryGeneratedColumn('uuid')
  uuid: string;

  @Column()
  name: string;

  @Column()
  isPublic: boolean;

  @CreateDateColumn()
  timestamp: Date;

  @OneToMany(() => OfferRequest, (offerRequest) => offerRequest.offer)
  requests: OfferRequest[];
}
