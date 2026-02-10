import { Body, Controller, Post } from '@nestjs/common';
import { AuthService } from './auth.service';
import { CustomerRegistrationDto, LoginDto } from 'src/dtos';

@Controller('auth')
export class AuthController {


    constructor (private authService: AuthService){}

    @Post("/register")
    async register(@Body() registrationDto: CustomerRegistrationDto){

        return await this.authService.register(registrationDto)

    }


    @Post("/login")
    async login(@Body() loginDto: LoginDto){
        return await this.authService.login(loginDto)
    }
    
}
