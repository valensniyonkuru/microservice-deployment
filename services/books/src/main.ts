import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { MicroserviceOptions,Transport } from '@nestjs/microservices';
import "dotenv/config"
async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  await app.listen(5000);

  const RABBITMQ_URL= process.env.RABBITMQ_URL 

  const miscroservice= app.connectMicroservice<MicroserviceOptions>({
    transport: Transport.RMQ,
    
    options:{
      urls:[RABBITMQ_URL],
       queue:"book_queue",
       queueOptions:{
        durable: true
       }
    }
  })
  await miscroservice.listen()
}
bootstrap();
