using Microsoft.EntityFrameworkCore;
using Backend.Models;

namespace Backend.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
        {
        }

        public DbSet<User> Users { get; set; }
        public DbSet<Vocabulary> Vocabularies { get; set; }
        public DbSet<WritingSubmission> WritingSubmissions { get; set; }
        public DbSet<UserStats> UserStats { get; set; }
        public DbSet<DailyActivity> DailyActivities { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Configure User
            modelBuilder.Entity<User>()
                .HasKey(u => u.Id);

            modelBuilder.Entity<User>()
                .HasIndex(u => u.Email)
                .IsUnique();

            modelBuilder.Entity<User>()
                .HasIndex(u => u.Username)
                .IsUnique();

            // Configure Vocabulary with User relationship
            modelBuilder.Entity<Vocabulary>()
                .HasKey(v => v.Id);

            modelBuilder.Entity<Vocabulary>()
                .HasOne(v => v.User)
                .WithMany(u => u.Vocabularies)
                .HasForeignKey(v => v.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<Vocabulary>()
                .Property(v => v.Word)
                .IsRequired()
                .HasMaxLength(100);

            // Configure WritingSubmission with User relationship
            modelBuilder.Entity<WritingSubmission>()
                .HasKey(w => w.Id);

            modelBuilder.Entity<WritingSubmission>()
                .HasOne(w => w.User)
                .WithMany(u => u.WritingSubmissions)
                .HasForeignKey(w => w.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<WritingSubmission>()
                .Property(w => w.Content)
                .IsRequired();

            // Configure UserStats with User relationship
            modelBuilder.Entity<UserStats>()
                .HasKey(u => u.Id);

            modelBuilder.Entity<UserStats>()
                .HasOne(u => u.User)
                .WithOne(u => u.UserStats)
                .HasForeignKey<UserStats>(u => u.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            // Configure DailyActivity
            modelBuilder.Entity<DailyActivity>()
                .HasKey(d => d.Id);

            modelBuilder.Entity<DailyActivity>()
                .Property(d => d.ActivityDate)
                .IsRequired();
        }
    }
}
