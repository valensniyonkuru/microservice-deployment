import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { CustomerModule } from './customer/customer.module';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Customer } from './entities/customer.entity';
import { ClientsModule, Transport } from '@nestjs/microservices';
import { AuthModule } from './auth/auth.module';

@Module({
  imports: [
    CustomerModule,
    ConfigModule.forRoot({
      isGlobal: true
    }),
    TypeOrmModule.forRoot({
      type: "postgres",
      host: "localhost",
      username: "pacifique",
      password: "myPassword123",
      database: "library_customers",
      entities: [Customer],
      synchronize: true
    }),
    AuthModule,
  ],
  controllers: [AppController],
  providers: [AppService],

})
export class AppModule { }
