import { Controller } from '@nestjs/common';
import { CustomerService } from './customer.service';
import { MessagePattern, Payload } from '@nestjs/microservices';

const GET_CUSTOMER = 'getCustomer';


@Controller('customer')
export class CustomerController {

    constructor(
        private readonly customerService: CustomerService
    ){}



}
