import { Router } from "express";
import controller from './controller'

const router = Router()

router.get('/vert', controller.getVertex)
router.get('/frag', controller.getFragment)
router.get('/', controller.home)

export default router