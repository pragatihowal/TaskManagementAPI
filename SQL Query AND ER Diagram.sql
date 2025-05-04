 1. Tables & Relationships
 
  Users Table
 CREATE TABLE Users (
    Id SERIAL PRIMARY KEY,
    Username VARCHAR(100) NOT NULL UNIQUE,
    Password VARCHAR(255) NOT NULL
);

 TaskModel Table
CREATE TABLE Tasks (
    Id SERIAL PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    Description TEXT,
    UserId INTEGER NOT NULL,
    FOREIGN KEY (UserId) REFERENCES Users(Id)
);

 TaskComments Table
CREATE TABLE TaskComments (
    Id SERIAL PRIMARY KEY,
    TaskId INTEGER NOT NULL,
    UserId INTEGER NOT NULL,
    Comment TEXT NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (TaskId) REFERENCES Tasks(Id),
    FOREIGN KEY (UserId) REFERENCES Users(Id)
);


2. ER Diagram
Table Users {
  Id int [pk, increment]
  Username varchar
  Password varchar
}

Table Tasks {
  Id int [pk, increment]
  Title varchar
  Description text
  UserId int [ref: > Users.Id]
}

Table TaskComments {
  Id int [pk, increment]
  TaskId int [ref: > Tasks.Id]
  UserId int [ref: > Users.Id]
  Comment text
  CreatedAt timestamp
}


3. Query
a)Get all tasks assigned to a user
SELECT 
    t.Id AS TaskId,
    t.Title,
    t.Description,
    u.Id AS UserId,
    u.Username
FROM Tasks t
JOIN Users u ON t.UserId = u.Id;

b)Get all comments on a task
SELECT 
    c.Id AS CommentId,
    c.Comment,
    c.CreatedAt,
    u.Id AS UserId,
    u.Username,
    t.Id AS TaskId,
    t.Title AS TaskTitle
FROM TaskComments c
JOIN Users u ON c.UserId = u.Id
JOIN Tasks t ON c.TaskId = t.Id
ORDER BY c.CreatedAt ASC;


3. Debugging & Code Fixing

//  Proper async return type and await
    public async Task<TaskModel?> GetTask(int id)
    {
        try
        {
            return await _dbContext.Set<TaskModel>().FirstOrDefaultAsync(t => t.Id == id);
        }
        catch (Exception ex)
        {
            // Log exception (optional)
            throw new Exception("Error retrieving the task.", ex);
        }
    }

    //  Return Task<List<TaskModel>> and use await
    public async Task<List<TaskModel>> GetAllTasks()
    {
        try
        {
            return await _dbContext.Set<TaskModel>().ToListAsync();
        }
        catch (Exception ex)
        {
            // Log exception (optional)
            throw new Exception("Error retrieving all tasks.", ex);
        }
    }


5)Unit Testing

using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Moq;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using TaskManagementAPI.Controllers;
using TaskManagementAPI.DbContext;
using TaskManagementAPI.Model;
using Xunit;

public class TaskManagementControllerTests
{
    private readonly Mock<TaskDbContext> _mockContext;
    private readonly TaskManagementController _controller;

    public TaskManagementControllerTests()
    {
        // Mock DbContext
        var options = new DbContextOptionsBuilder<TaskDbContext>()
            .UseInMemoryDatabase(databaseName: "TestDatabase")
            .Options;
        var context = new TaskDbContext(options);

        _mockContext = new Mock<TaskDbContext>(options);
        _controller = new TaskManagementController(context);
    }

    [Fact]
    public async Task Create_ValidTask_ReturnsCreatedAtAction()
    {
        // Arrange
        var task = new TaskModel { Id = 1, Title = "Test Task", Description = "Test Description", UserId = 1 };

        // Act
        var result = await _controller.Create(task);

        // Assert
        var createdResult = Assert.IsType<CreatedAtActionResult>(result);
        Assert.Equal("GetById", createdResult.ActionName);
    }

    [Fact]
    public async Task GetById_ExistingTask_ReturnsOk()
    {
        // Arrange
        var task = new TaskModel { Id = 1, Title = "Test Task", Description = "Test Description", UserId = 1 };
        _mockContext.Setup(c => c.tasks.FindAsync(1)).ReturnsAsync(task);

        // Act
        var result = await _controller.GetById(1);

        // Assert
        var okResult = Assert.IsType<OkObjectResult>(result);
        var returnedTask = Assert.IsType<TaskModel>(okResult.Value);
        Assert.Equal(task.Id, returnedTask.Id);
    }

    [Fact]
    public async Task GetById_NonExistingTask_ReturnsNotFound()
    {
        // Arrange
        _mockContext.Setup(c => c.tasks.FindAsync(1)).ReturnsAsync((TaskModel)null);

        // Act
        var result = await _controller.GetById(1);

        // Assert
        Assert.IsType<NotFoundResult>(result);
    }
}

Explanation of the Tests:
1.	Create_ValidTask_ReturnsCreatedAtAction:
•	Tests the Create method with a valid task.
•	Verifies that the response is a CreatedAtActionResult and points to the GetById method.
2.	GetById_ExistingTask_ReturnsOk:
•	Tests the GetById method with an existing task.
•	Verifies that the response is OkObjectResult and contains the correct task.
3.	GetById_NonExistingTask_ReturnsNotFound:
•	Tests the GetById method with a non-existing task.
•	Verifies that the response is NotFoundResult.