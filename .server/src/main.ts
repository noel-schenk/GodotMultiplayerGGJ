import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { INestApplication } from '@nestjs/common';

const swagger = (app: INestApplication<any>) => {
  const config = new DocumentBuilder()
    .setTitle('API Documentation')
    .setDescription('API description')
    .setVersion('1.0')
    .addTag('API')
    .build();

  // Create Swagger document
  const document = SwaggerModule.createDocument(app, config);

  // Setup Swagger module
  SwaggerModule.setup('api-docs', app, document);
};

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  await app.listen(process.env.PORT || 3000);

  swagger(app);
}
bootstrap();
