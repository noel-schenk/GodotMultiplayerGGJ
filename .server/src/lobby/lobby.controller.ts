import { Controller, Post, Get, Body, Query, HttpStatus } from '@nestjs/common';
import { LobbyService } from './lobby.service';
import { Lobby } from './lobby.entity';

@Controller()
export class LobbyController {
  constructor(private readonly lobbyService: LobbyService) {}

  @Post('create-lobby')
  async createLobby(@Body() data: any): Promise<Lobby> {
    return this.lobbyService.createLobby(data);
  }

  @Get('get-lobbies')
  async getLobbies(
    @Query('project') project: string,
    @Query('name') name?: string,
  ): Promise<any> {
    if (!project) {
      return { error: 'Project name is required' };
    }
    if (name) {
      return this.lobbyService.getLobby(project, name);
    }
    return this.lobbyService.getPublicLobbies(project);
  }

  @Post('add-client')
  async addClient(@Body() data: any): Promise<{ message: string }> {
    await this.lobbyService.addClient(data);
    return { message: 'Client added' };
  }
}
