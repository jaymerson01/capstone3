"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const meta_controller_1 = require("../controllers/meta.controller");
const router = (0, express_1.Router)();
router.get('/categories', meta_controller_1.getCategories);
router.get('/areas', meta_controller_1.getAreas);
exports.default = router;
