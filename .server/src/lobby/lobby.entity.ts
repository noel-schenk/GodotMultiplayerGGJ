import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
} from 'typeorm';

@Entity('lobbies')
export class Lobby {
  @PrimaryGeneratedColumn()
  id: number;

  @Column('json')
  offer: any;

  @Column('json')
  ice: any;

  @Column({ default: false })
  is_public: boolean;

  @Column()
  project: string;

  @Column()
  name: string;

  @CreateDateColumn()
  timestamp: Date;

  @Column('json', { default: [] })
  clients: any[];
}
