import { Injectable, NotFoundException } from '@nestjs/common';
import { Repository, LessThan } from 'typeorm';
import { InjectRepository } from '@nestjs/typeorm';
import { Lobby } from './lobby.entity';
import { ClientRequest, LobbyRequest } from './../Types';

@Injectable()
export class LobbyService {
  constructor(
    @InjectRepository(Lobby)
    private lobbyRepository: Repository<Lobby>,
  ) {}

  private async cleanupOldLobbies() {
    const date = new Date();
    date.setDate(date.getDate() - 1);
    await this.lobbyRepository.delete({ timestamp: LessThan(date) });
  }

  async createLobby(data: LobbyRequest): Promise<Lobby> {
    await this.cleanupOldLobbies();
    const lobby = this.lobbyRepository.create({
      ...data,
      is_public: Boolean(data.is_public),
      clients: [],
    });
    await this.lobbyRepository.save(lobby);
    return this.getLobby(data.project, data.name);
  }

  async getPublicLobbies(project: string): Promise<Lobby[]> {
    await this.cleanupOldLobbies();
    return this.lobbyRepository.find({ where: { project, is_public: true } });
  }

  async getLobby(project: string, name: string): Promise<Lobby> {
    await this.cleanupOldLobbies();
    const lobby = await this.lobbyRepository.findOne({
      where: { project, name },
    });
    if (!lobby) {
      throw new NotFoundException('Lobby not found');
    }
    return lobby;
  }

  async addClient(data: ClientRequest): Promise<void> {
    await this.cleanupOldLobbies();
    const lobby = await this.getLobby(data.project, data.name);
    const newClient = { offer: data.offer, ice: data.ice };
    lobby.clients.push(newClient);
    await this.lobbyRepository.save(lobby);
  }
}
