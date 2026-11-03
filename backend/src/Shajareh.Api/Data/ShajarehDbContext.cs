using Microsoft.EntityFrameworkCore;

namespace Shajareh.Api.Data;

public sealed class ShajarehDbContext(DbContextOptions<ShajarehDbContext> options) : DbContext(options)
{
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasDefaultSchema("public");

        modelBuilder.Entity<Family>().ToTable("families");
        modelBuilder.Entity<Person>().ToTable("persons");
        modelBuilder.Entity<FamilyPerson>().ToTable("family_persons")
            .HasKey(x => new { x.FamilyId, x.PersonId });
        modelBuilder.Entity<FamilyMembership>().ToTable("family_memberships")
            .HasIndex(x => new { x.FamilyId, x.PersonId }).IsUnique();
        modelBuilder.Entity<Relationship>().ToTable("relationships")
            .HasIndex(x => new { x.FamilyId, x.PersonId });
        modelBuilder.Entity<UserAccount>().ToTable("user_accounts")
            .HasIndex(x => x.PersonId).IsUnique();
        modelBuilder.Entity<UserAccount>()
            .HasIndex(x => x.PhoneNumber).IsUnique();
    }
}

public sealed class Family
{
    public Guid Id { get; set; }
    public required string Name { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
}

public sealed class Person
{
    public Guid Id { get; set; }
    public required string GivenName { get; set; }
    public string? FamilyName { get; set; }
    public DateOnly? BirthDate { get; set; }
    public string BirthDatePrecision { get; set; } = "unknown";
    public string LifeStatus { get; set; } = "unknown";
    public DateTimeOffset CreatedAt { get; set; }
}

public sealed class FamilyPerson
{
    public Guid FamilyId { get; set; }
    public Guid PersonId { get; set; }
    public string RecordStatus { get; set; } = "active";
    public DateTimeOffset AddedAt { get; set; }
}

public sealed class FamilyMembership
{
    public Guid Id { get; set; }
    public Guid FamilyId { get; set; }
    public Guid PersonId { get; set; }
    public string Role { get; set; } = "member";
    public string Status { get; set; } = "active";
    public DateTimeOffset JoinedAt { get; set; }
}

public sealed class Relationship
{
    public Guid Id { get; set; }
    public Guid FamilyId { get; set; }
    public Guid PersonId { get; set; }
    public Guid RelatedPersonId { get; set; }
    public string Type { get; set; } = "parent_child";
    public string? ParentRole { get; set; }
    public string Status { get; set; } = "proposed";
    public Guid CreatedByPersonId { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
}

public sealed class UserAccount
{
    public Guid Id { get; set; }
    public Guid PersonId { get; set; }
    public string PhoneNumber { get; set; } = "";
    public bool PhoneVerified { get; set; }
    public string PasswordHash { get; set; } = "";
    public DateTimeOffset CreatedAt { get; set; }
}
