using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using TaskManagementAPI.Model;
using TaskModel = TaskManagementAPI.Model.TaskModel;

namespace TaskManagementAPI.DbContext
{
    public class TaskDbContext : Microsoft.EntityFrameworkCore.DbContext // Fix for CS0311
    {
        public TaskDbContext(DbContextOptions<TaskDbContext> options) : base(options) { } // Fix for CS1729

        public DbSet<TaskModel> tasks { get; set; } 
        public DbSet<User> users { get; set; }
    }
}
