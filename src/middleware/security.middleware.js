import aj from '#config/arcjet.js';
import logger from '#config/logger.js';
import { slidingWindow } from '@arcjet/node';

const securityMiddleware = (req, res, next) => {
    next();
};

export default securityMiddleware;
        
        next();
        
    } catch (e) {
        console.error('Arcjet middleware error:', e);
        res.status(500).json({ error: 'Internal server error', message: 'Something went wrong with security middleware' });
    }
};

export default securityMiddleware;