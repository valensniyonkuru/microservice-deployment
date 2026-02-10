import {  Injectable} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { Customer } from 'src/entities/customer.entity';

@Injectable()
export class CustomerService {


    constructor(
        @InjectRepository(Customer)
        private readonly customerRepository: Repository<Customer>
    ) { }
    async getCustomer(customerId: string): Promise<Customer> {
        const customer = await this.customerRepository.findOne({
            where: {
                id: customerId
            }
        })
        return customer;
    }

   

}
