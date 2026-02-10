import { Module } from '@nestjs/common';
import { BookService } from './book.service';
import { BookController } from './book.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Book } from 'src/entities/book.entity';
import { ClientsModule, Transport } from '@nestjs/microservices';

@Module({
  providers: [BookService],
  controllers: [BookController],
  imports:[
    TypeOrmModule.forFeature([Book]),
    ClientsModule.register([
      {
          name: "BOOK_SERVICE",
           transport: Transport.RMQ,
           options: {
              urls: [process.env.RABBITMQ_URL],
              queue: "book_queue",
              queueOptions:{
                  durable: true
              }
           }
      },
      {
          name: "ORDER_SERVICE",
          transport: Transport.RMQ,
          options:{
              urls:[process.env.RABBITMQ_URL],
              queue:"order_queue",
              queueOptions:{
                  durable: false
              }
          }
      },
      {
          name: "CUSTOMER_SERVICE",
          transport: Transport.RMQ,
          options:{
              urls:[process.env.RABBITMQ_URL],
              queue:"customer_queue",
              queueOptions:{
                  durable: false
              }
          }
      }
  ])
  ],
  exports: [BookService],
})
export class BookModule {}
