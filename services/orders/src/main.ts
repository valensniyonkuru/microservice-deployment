import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { MicroserviceOptions,Transport } from '@nestjs/microservices';
import "dotenv/config"
async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  await app.listen(4000);
  const RABBITMQ_URL= process.env.RABBITMQ_URL 

  app.enableCors()

  const miscroservice= app.connectMicroservice<MicroserviceOptions>({
    transport: Transport.RMQ,
    options:{
      urls:[RABBITMQ_URL],
      queue: "order_queue",
      queueOptions: {
         durable:false
      }
    }
  })
  await miscroservice.listen();
}
bootstrap();
