import express from 'express';
import { signup, signin, signout } from '../controllers/auth.controller.js';

const router = express.Router();

router.post('/sign-up', signup);

router.post('/sign-in', signin);

router.post('/sign-out', signout);

router.get('/', (req, res) => res.send('GET /users')); 
router.get('/:id', (req, res) => res.send('GET /users/:id')); 
router.put('/:id', (req, res) => res.send('PUT /users/:id')); 
router.delete('/:id', (req, res) => res.send('GET /users/:id')); 

export default router;