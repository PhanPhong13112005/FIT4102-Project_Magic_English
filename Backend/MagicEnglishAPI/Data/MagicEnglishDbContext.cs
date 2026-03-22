using Microsoft.EntityFrameworkCore;
using MagicEnglishAPI.Models;

namespace MagicEnglishAPI.Data;

/// <summary>
/// Database context for Magic English API
/// </summary>
public class MagicEnglishDbContext : DbContext
{
    public MagicEnglishDbContext(DbContextOptions<MagicEnglishDbContext> options) : base(options)
    {
    }

    public DbSet<User> Users { get; set; }
    public DbSet<Vocabulary> Vocabularies { get; set; }
    public DbSet<GrammarCheck> GrammarChecks { get; set; }
    public DbSet<StudyActivity> StudyActivities { get; set; }
    public DbSet<Streak> Streaks { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // User configuration
        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.HasIndex(e => e.Email).IsUnique();
            entity.Property(e => e.Name).HasMaxLength(100).IsRequired();
            entity.Property(e => e.Email).HasMaxLength(256).IsRequired();
        });

        // Vocabulary configuration
        modelBuilder.Entity<Vocabulary>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Word).HasMaxLength(100).IsRequired();
            entity.Property(e => e.IPA).HasMaxLength(100);
            entity.Property(e => e.Meaning).HasMaxLength(500).IsRequired();
            entity.Property(e => e.PartOfSpeech).HasMaxLength(50);
            entity.Property(e => e.Example).HasMaxLength(500);
            entity.Property(e => e.CEFRLevel).HasMaxLength(2);

            // Foreign key relationship
            entity.HasOne(e => e.User)
                  .WithMany(u => u.Vocabularies)
                  .HasForeignKey(e => e.UserId)
                  .OnDelete(DeleteBehavior.Cascade);
        });

        // GrammarCheck configuration
        modelBuilder.Entity<GrammarCheck>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.OriginalText).HasMaxLength(2000).IsRequired();
            entity.Property(e => e.Score).HasPrecision(5, 2);
            entity.Property(e => e.Errors).HasColumnType("nvarchar(max)");
            entity.Property(e => e.Suggestions).HasColumnType("nvarchar(max)");

            // Foreign key relationship
            entity.HasOne(e => e.User)
                  .WithMany(u => u.GrammarChecks)
                  .HasForeignKey(e => e.UserId)
                  .OnDelete(DeleteBehavior.Cascade);
        });

        // StudyActivity configuration
        modelBuilder.Entity<StudyActivity>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.ActivityType).HasConversion<string>();

            // Foreign key relationship
            entity.HasOne(e => e.User)
                  .WithMany(u => u.StudyActivities)
                  .HasForeignKey(e => e.UserId)
                  .OnDelete(DeleteBehavior.Cascade);
        });

        // Streak configuration
        modelBuilder.Entity<Streak>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.HasIndex(e => e.UserId).IsUnique();

            // Foreign key relationship
            entity.HasOne(e => e.User)
                  .WithOne(u => u.Streak)
                  .HasForeignKey<Streak>(e => e.UserId)
                  .OnDelete(DeleteBehavior.Cascade);
        });
    }
}
