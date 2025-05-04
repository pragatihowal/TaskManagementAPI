using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TaskManagementAPI.DbContext;
using TaskManagementAPI.Model;

namespace TaskManagementAPI.Controllers
{
    [Route("[controller]")]
    [ApiController]
    public class TaskManagementController : ControllerBase
    {
        private readonly TaskDbContext _context;

        public TaskManagementController(TaskDbContext context)
        {
            _context = context;
        }
    

    [HttpPost]
        [Authorize(Roles = "Admin,User")]
        public async Task<IActionResult> Create(TaskModel task)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            _context.tasks.Add(task);
            await _context.SaveChangesAsync();
            return CreatedAtAction(nameof(GetById), new { id = task.Id }, task);
        }

        [HttpGet("{id}")]
        [Authorize(Roles = "Admin,User")]
        public async Task<IActionResult> GetById(int id)
        {
            var task = await _context.tasks.FindAsync(id);
            if (task == null) return NotFound();
            return Ok(task);
        }

        [HttpGet("user/{userId}")]
        [Authorize(Roles = "Admin,User")]
        public async Task<IActionResult> GetByUser(int userId)
        {
            var tasks = await _context.tasks
                .Where(t => t.UserId == userId)
                .ToListAsync();
            return Ok(tasks);
        }
    }
}