<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Middleware\HandleCors;
use Illuminate\Http\Request;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        apiPrefix: 'api/v1',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        $middleware->prepend(HandleCors::class);
        $middleware->redirectGuestsTo(fn () => null);
        $middleware->alias(['admin' => \App\Http\Middleware\EnsureAdmin::class]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        // Always return JSON for API routes
        $exceptions->shouldRenderJsonWhen(
            fn (Request $request) => $request->is('api/*'),
        );

        // Return 401 JSON instead of redirecting to non-existent 'login' route
        $exceptions->render(function (
            \Illuminate\Auth\AuthenticationException $e,
            Request $request,
        ) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        });
    })->create();


