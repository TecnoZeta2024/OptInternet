using OptiGemini.Desktop.ViewModels;
using System.Windows;

namespace OptiGemini.Desktop.Views;

/// <summary>
/// Main application window
/// </summary>
public partial class MainWindow : Window
{
    public MainWindow(MainWindowViewModel viewModel)
    {
        InitializeComponent();
        DataContext = viewModel;
    }
}
