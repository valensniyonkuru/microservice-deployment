import { BadRequestException, Injectable, UnauthorizedException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { CustomerRegistrationDto } from 'src/dtos';
import { Customer } from 'src/entities/customer.entity';
import { Repository } from 'typeorm';
import * as bcrypt from 'bcrypt'
import jwt from 'jsonwebtoken'
import { LoginDto } from 'src/dtos';
import { JwtService } from '@nestjs/jwt';
@Injectable()
export class AuthService {
    constructor(
        @InjectRepository(Customer)
        private readonly customerRepository: Repository<Customer>,
        private jwtService: JwtService
    ) { }

    async register(customerRegistrationDto: CustomerRegistrationDto): Promise<{ customer: Customer, token: string }> {
        const { name, email, phone, password } = customerRegistrationDto
        const existingUser = await this.customerRepository.findOne({
            where: {
                email
            }
        })

        if (existingUser) throw new BadRequestException("User already exists!");
        // Create a new user in the database

        const salt = await bcrypt.genSalt(10);
        const hash = await bcrypt.hash(password, salt)
        const newUser = this.customerRepository.create({
            name,
            email,
            phone,
            password: hash
        })

        await this.customerRepository.save(newUser);

        // generate token
        const token = await this.signToken(email, newUser.id);
        return {
            customer: newUser,
            token: token

        }
    }

    signToken = async (email: string, id: string): Promise<string> => {

        const payload = {
            sub: id,
            email
        }
        const token = await this.jwtService.signAsync(payload,{
            secret: process.env.JWT_SECRET_KEY,
            expiresIn: "2d"
            
        })

        return token;
    }


    async login(loginDto: LoginDto): Promise<{user: Customer, token:string}> {
        const { email, password } = loginDto
        try {

            const user = await this.customerRepository.findOne({
                where: {
                    email
                }
            })
            if (!user) throw new UnauthorizedException("Invalid Credentials.Please try again!")

            const match = await bcrypt.compare(password, user.password);
            if (!match) throw new UnauthorizedException("Invalid Credentials. Please try again!")

            const token = await this.signToken(user.email, user.id);
            return {
                user,
                token
            };
        } catch (error) {
            console.log(error);

        }

    }


}
