import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Lobby } from './lobby.entity';
import { LobbyService } from './lobby.service';
import { LobbyController } from './lobby.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Lobby])],
  controllers: [LobbyController],
  providers: [LobbyService],
})
export class LobbyModule {}
