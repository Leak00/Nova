<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\TaskController;
use App\Http\Controllers\UserController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::get('/user', [AuthController::class, 'users']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);

    Route::apiResource('tasks', TaskController::class)->except(['create', 'edit']);
    Route::post('/tasks/{task}/restore', [TaskController::class, 'restore']);
    Route::delete('/tasks/{task}/force', [TaskController::class, 'forceDelete']);

    Route::match(['put', 'patch'], '/users/{id}', [UserController::class, 'update']);
});

Route::post('/users', [UserController::class, 'store']);
