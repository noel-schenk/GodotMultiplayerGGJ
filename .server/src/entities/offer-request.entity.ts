import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  ManyToOne,
  CreateDateColumn,
} from 'typeorm';
import { Offer } from './offer.entity';

@Entity('offer_requests')
export class OfferRequest {
  @PrimaryGeneratedColumn('uuid')
  uuid: string;

  @CreateDateColumn()
  timestamp: Date;

  @Column({ default: false })
  isResolved: boolean;

  @Column({ type: 'jsonb', nullable: true })
  exchange: {
    server?: {
      iceCandidates: Array<{
        media: string;
        index: number;
        name: string;
      }>;
      sessionDescription: {
        type: string;
        sdp: string;
      };
    };
    client?: {
      iceCandidates: Array<{
        media: string;
        index: number;
        name: string;
      }>;
      sessionDescription: {
        type: string;
        sdp: string;
      };
    };
  };

  @ManyToOne(() => Offer, (offer) => offer.requests)
  offer: Offer;
}
