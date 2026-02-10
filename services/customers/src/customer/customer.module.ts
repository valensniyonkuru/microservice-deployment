import { Module } from '@nestjs/common';
import { CustomerController } from './customer.controller';
import { CustomerService } from './customer.service';
import { ClientsModule, Transport } from '@nestjs/microservices';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Customer } from 'src/entities/customer.entity';
@Module({
  controllers: [CustomerController],
  providers: [CustomerService],
  imports:[
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
  ]),
  TypeOrmModule.forFeature([Customer])
  ],
  exports:[CustomerService]
  
})
export class CustomerModule {}
