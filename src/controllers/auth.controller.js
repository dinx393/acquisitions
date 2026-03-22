import logger from '#config/logger.js';
import { createUser, authenticateUser } from '#services/auth.services.js';
import { formatValidationError } from '#utils/format.js';
import { signupSchema, signInSchema } from '#validations/auth.validation.js';
import jwt from 'jsonwebtoken';

export const signup = async (req, res, next) => {
    try {
        // Валидация входящих данных
        const validationResult = signupSchema.safeParse(req.body);
        if (!validationResult.success) {
            return res.status(400).json({
                error: 'Validation failed',
                details: formatValidationError(validationResult.error)
            });
        }

        const { name, email, password, role } = validationResult.data;

        // Создание пользователя
        const user = await createUser({ name, email, password, role });

        // Генерация JWT
        const token = jwt.sign(
            { id: user.id, email: user.email, role: user.role },
            process.env.JWT_SECRET,
            { expiresIn: '1d' }
        );

        // Ставим cookie с токеном
        res.cookie('token', token, {
            httpOnly: true,
            secure: process.env.NODE_ENV === 'production',
            sameSite: 'strict',
            maxAge: 24 * 60 * 60 * 1000 // 1 день
        });

        logger.info(`User registered successfully: ${email}`);

        // Ответ клиенту
        res.status(201).json({
            message: 'User registered',
            user: {
                id: user.id,
                name: user.name,
                email: user.email,
                role: user.role
            }
        });

    } catch (e) {
        logger.error('Signup error', e);

        // Обработка ошибки дубликата email
        const errorMessage = e.message || e.toString();
        if (errorMessage.toLowerCase().includes('exist') || e.code === 'P2002') {
            return res.status(409).json({ error: 'Email already exists' });
        }

        next(e);
    }
};

export const signin = async (req, res, next) => {
    try {
        // Валидация входящих данных
        const validationResult = signInSchema.safeParse(req.body);
        if (!validationResult.success) {
            return res.status(400).json({
                error: 'Validation failed',
                details: formatValidationError(validationResult.error)
            });
        }

        const { email, password } = validationResult.data;

        // Аутентификация пользователя
        const user = await authenticateUser({ email, password });

        // Генерация JWT
        const token = jwt.sign(
            { id: user.id, email: user.email, role: user.role },
            process.env.JWT_SECRET,
            { expiresIn: '1d' }
        );

        // Ставим cookie с токеном
        res.cookie('token', token, {
            httpOnly: true,
            secure: process.env.NODE_ENV === 'production',
            sameSite: 'strict',
            maxAge: 24 * 60 * 60 * 1000 // 1 день
        });

        logger.info(`User signed in successfully: ${email}`);

        // Ответ клиенту
        res.status(200).json({
            message: 'User signed in',
            user: {
                id: user.id,
                name: user.name,
                email: user.email,
                role: user.role
            }
        });

    } catch (e) {
        logger.error('Signin error', e);

        // Обработка ошибок аутентификации
        const errorMessage = e.message || e.toString();
        if (errorMessage.toLowerCase().includes('not found') || errorMessage.toLowerCase().includes('invalid password')) {
            return res.status(401).json({ error: 'Invalid credentials' });
        }

        next(e);
    }
};

export const signout = async (req, res, next) => {
    try {
        // Очищаем cookie с токеном
        res.clearCookie('token', {
            httpOnly: true,
            secure: process.env.NODE_ENV === 'production',
            sameSite: 'strict'
        });

        logger.info('User signed out successfully');

        // Ответ клиенту
        res.status(200).json({
            message: 'User signed out successfully'
        });

    } catch (e) {
        logger.error('Signout error', e);
        next(e);
    }
};
