<?php

namespace App\Http\Controllers;

use App\Models\Task;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class TaskController extends Controller
{
    protected function taskQuery(Request $request)
    {
        return Task::query()
            ->when($request->query('deleted') !== null, function ($query) use ($request) {
                return $query->where('is_deleted', $request->boolean('deleted'));
            }, function ($query) {
                return $query->where('is_deleted', false);
            })
            ->when($request->query('category'), function ($query, $category) {
                return $query->where('category', $category);
            })
            ->when($request->user(), function ($query, $user) {
                return $query->where('user_id', $user->id);
            });
    }

    public function index(Request $request)
    {
        $tasks = $this->taskQuery($request)
            ->orderBy('updated_at', 'desc')
            ->get();

        return response()->json(['tasks' => $tasks]);
    }

    public function store(Request $request)
    {
        $attributes = $request->validate([
            'id' => 'sometimes|string|unique:tasks,id',
            'title' => 'required|string|max:255',
            'category' => 'sometimes|string|max:255',
            'is_done' => 'sometimes|boolean',
        ]);

        $attributes['id'] = $attributes['id'] ?? Str::uuid()->toString();
        $attributes['category'] = $attributes['category'] ?? 'General';
        $attributes['is_done'] = $request->boolean('is_done', false);
        $attributes['is_deleted'] = false;
        $attributes['deleted_at'] = null;

        if ($request->user()) {
            $attributes['user_id'] = $request->user()->id;
        }

        $task = Task::create($attributes);

        return response()->json([
            'message' => 'Task created successfully',
            'task' => $task,
        ], 201);
    }

    public function show(Request $request, Task $task)
    {
        if ($request->user() && $task->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        return response()->json(['task' => $task]);
    }

    public function update(Request $request, Task $task)
    {
        if ($request->user() && $task->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $attributes = $request->validate([
            'title' => 'sometimes|required|string|max:255',
            'category' => 'sometimes|string|max:255',
            'is_done' => 'sometimes|boolean',
            'is_deleted' => 'sometimes|boolean',
        ]);

        if (array_key_exists('is_deleted', $attributes) && $attributes['is_deleted'] === false) {
            $attributes['deleted_at'] = null;
        }

        if (array_key_exists('is_deleted', $attributes) && $attributes['is_deleted'] === true && $task->deleted_at === null) {
            $attributes['deleted_at'] = now();
        }

        $task->update($attributes);

        return response()->json([
            'message' => 'Task updated successfully',
            'task' => $task,
        ]);
    }

    public function destroy(Request $request, Task $task)
    {
        if ($request->user() && $task->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $task->update([
            'is_deleted' => true,
            'deleted_at' => now(),
        ]);

        return response()->json([
            'message' => 'Task moved to trash',
            'task' => $task,
        ]);
    }

    public function restore(Request $request, Task $task)
    {
        if ($request->user() && $task->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $task->update([
            'is_deleted' => false,
            'deleted_at' => null,
        ]);

        return response()->json([
            'message' => 'Task restored successfully',
            'task' => $task,
        ]);
    }

    public function forceDelete(Request $request, Task $task)
    {
        if ($request->user() && $task->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $task->delete();

        return response()->json([
            'message' => 'Task permanently deleted',
        ]);
    }
}
