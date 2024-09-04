package start

import (
	"context"
	"fmt"
	"time"

	"github.com/spf13/cobra"
	"opencsg.com/portal/internal/config"
	"opencsg.com/portal/pkg/database"
	"opencsg.com/portal/pkg/database/migrations"
)

func init() {
	Cmd.AddCommand(serverCmd)
}

var Cmd = &cobra.Command{
	Use:   "start",
	Short: "start a server",
	PersistentPreRunE: func(cmd *cobra.Command, args []string) error {
		ctx, cancel := context.WithTimeout(cmd.Context(), 10*time.Second)
		defer cancel()

		dbConfig := database.DBConfig{
			Dialect: database.DatabaseDialect(config.Env("DB_DIALECT", "pg").(string)),
			DSN:     config.Env("DB_DSN", "postgresql://postgres:postgres@localhost:5432/csghub_development?sslmode=disable").(string),
		}

		db, err := database.NewDB(dbConfig)
		if err != nil {
			return fmt.Errorf("initializing DB: %w", err)
		}
		migrator := migrations.NewMigrator(db)

		status, err := migrator.MigrationsWithStatus(ctx)
		if err != nil {
			return fmt.Errorf("checking migrations status: %w", err)
		}

		unapplied := status.Unapplied()
		if len(unapplied) > 0 {
			return fmt.Errorf("there are %d migrations to apply: %s", len(unapplied), unapplied)
		}
		return nil
	},
	RunE: func(cmd *cobra.Command, args []string) error {
		return cmd.Help()
	},
}