using Microsoft.Deployment.WindowsInstaller;
using Microsoft.Win32;
using System.IO.Compression;

namespace OptiGemini.CustomActions;

/// <summary>
/// Custom actions for OptiGemini MSI installer.
/// Handles prerequisite validation and profile backup during uninstall.
/// </summary>
public class CustomActions
{
    private const string DotNetDownloadUrl = "https://dotnet.microsoft.com/download/dotnet/7.0";
    private const string PowerShellDownloadUrl = "https://aka.ms/install-powershell-windows";

    /// <summary>
    /// Checks if .NET Desktop Runtime 7.x is installed.
    /// </summary>
    [CustomAction]
    public static ActionResult CheckDotNetDesktopRuntime(Session session)
    {
        session.Log("Begin CheckDotNetDesktopRuntime");

        try
        {
            bool isInstalled = IsDotNet7DesktopRuntimeInstalled();

            if (!isInstalled)
            {
                string message = ".NET Desktop Runtime 7.0 or higher is required to run OptiGemini.\n\n" +
                                "Would you like to download it now?\n\n" +
                                $"Download URL: {DotNetDownloadUrl}";

                Record record = new Record(0);
                record.FormatString = message;

                MessageResult result = session.Message(
                    InstallMessage.User | (InstallMessage)MessageBoxButtons.YesNo | (InstallMessage)MessageBoxIcon.Warning,
                    record);

                if (result == MessageResult.Yes)
                {
                    System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo
                    {
                        FileName = DotNetDownloadUrl,
                        UseShellExecute = true
                    });
                }

                session.Log(".NET Desktop Runtime 7.x not found - installation aborted by user");
                return ActionResult.Failure;
            }

            session.Log(".NET Desktop Runtime 7.x detected - prerequisite satisfied");
            return ActionResult.Success;
        }
        catch (Exception ex)
        {
            session.Log($"ERROR in CheckDotNetDesktopRuntime: {ex.Message}");
            return ActionResult.Failure;
        }
    }

    /// <summary>
    /// Checks if PowerShell 7.4 or higher is installed.
    /// </summary>
    [CustomAction]
    public static ActionResult CheckPowerShell74(Session session)
    {
        session.Log("Begin CheckPowerShell74");

        try
        {
            var (isInstalled, version) = IsPowerShell74OrHigherInstalled();

            if (!isInstalled)
            {
                string message = "PowerShell 7.4 or higher is recommended for OptiGemini.\n\n" +
                                "The application can run in limited mode without it, but some features may be unavailable.\n\n" +
                                "Would you like to download PowerShell 7.4 now?\n\n" +
                                $"Download URL: {PowerShellDownloadUrl}";

                Record record = new Record(0);
                record.FormatString = message;

                MessageResult result = session.Message(
                    InstallMessage.User | (InstallMessage)MessageBoxButtons.YesNo | (InstallMessage)MessageBoxIcon.Information,
                    record);

                if (result == MessageResult.Yes)
                {
                    System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo
                    {
                        FileName = PowerShellDownloadUrl,
                        UseShellExecute = true
                    });
                }

                session.Log($"PowerShell 7.4+ not found (detected: {version}) - continuing with limited mode support");
                // Note: We return Success here as PowerShell is optional (limited mode)
                return ActionResult.Success;
            }

            session.Log($"PowerShell {version} detected - prerequisite satisfied");
            return ActionResult.Success;
        }
        catch (Exception ex)
        {
            session.Log($"ERROR in CheckPowerShell74: {ex.Message}");
            // Non-fatal - continue installation
            return ActionResult.Success;
        }
    }

    /// <summary>
    /// Backs up user profiles before uninstall.
    /// </summary>
    [CustomAction]
    public static ActionResult BackupUserProfiles(Session session)
    {
        session.Log("Begin BackupUserProfiles");

        try
        {
            string appDataPath = Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData);
            string profilesPath = Path.Combine(appDataPath, "OptiGemini", "profiles");
            
            if (!Directory.Exists(profilesPath))
            {
                session.Log("No profiles folder found - skipping backup");
                return ActionResult.Success;
            }

            string[] profileFiles = Directory.GetFiles(profilesPath, "*.json", SearchOption.AllDirectories);
            
            if (profileFiles.Length == 0)
            {
                session.Log("No profile files found - skipping backup");
                return ActionResult.Success;
            }

            string timestamp = DateTime.Now.ToString("yyyyMMdd_HHmmss");
            string backupFileName = $"OptiGemini_Profiles_Backup_{timestamp}.zip";
            string backupPath = Path.Combine(appDataPath, "OptiGemini", backupFileName);

            session.Log($"Creating backup: {backupPath}");

            // Create backup zip
            if (File.Exists(backupPath))
            {
                File.Delete(backupPath);
            }

            ZipFile.CreateFromDirectory(profilesPath, backupPath, CompressionLevel.Optimal, false);

            session.Log($"Profile backup created successfully: {backupPath} ({profileFiles.Length} files)");
            
            // Log backup location for user
            string message = $"Your OptiGemini profiles have been backed up to:\n{backupPath}\n\n" +
                           $"You can restore these profiles if you reinstall OptiGemini.";
            
            Record record = new Record(0);
            record.FormatString = message;
            session.Message(InstallMessage.Info, record);

            return ActionResult.Success;
        }
        catch (Exception ex)
        {
            session.Log($"ERROR in BackupUserProfiles: {ex.Message}");
            // Non-fatal - continue uninstall even if backup fails
            session.Log("Continuing uninstall despite backup failure");
            return ActionResult.Success;
        }
    }

    #region Private Helper Methods

    private static bool IsDotNet7DesktopRuntimeInstalled()
    {
        try
        {
            // Check registry for .NET Desktop Runtime 7.x
            using var key = Registry.LocalMachine.OpenSubKey(@"SOFTWARE\dotnet\Setup\InstalledVersions\x64\sharedfx\Microsoft.WindowsDesktop.App");
            
            if (key == null)
                return false;

            foreach (string versionName in key.GetSubKeyNames())
            {
                if (versionName.StartsWith("7."))
                {
                    return true;
                }
            }

            return false;
        }
        catch
        {
            return false;
        }
    }

    private static (bool isInstalled, string version) IsPowerShell74OrHigherInstalled()
    {
        try
        {
            // Check registry for PowerShell 7.x installation
            using var key = Registry.LocalMachine.OpenSubKey(@"SOFTWARE\Microsoft\PowerShellCore\InstalledVersions");
            
            if (key == null)
                return (false, "Not installed");

            foreach (string versionGuid in key.GetSubKeyNames())
            {
                using var versionKey = key.OpenSubKey(versionGuid);
                if (versionKey != null)
                {
                    var semVer = versionKey.GetValue("SemanticVersion") as string;
                    if (semVer != null && Version.TryParse(semVer.Split('-')[0], out Version? version))
                    {
                        if (version.Major >= 7 && version.Minor >= 4)
                        {
                            return (true, semVer);
                        }
                    }
                }
            }

            return (false, "Version < 7.4");
        }
        catch (Exception ex)
        {
            return (false, $"Error: {ex.Message}");
        }
    }

    #endregion
}
