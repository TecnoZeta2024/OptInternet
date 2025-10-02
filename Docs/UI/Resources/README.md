# UI Resources (Design Tokens)

This folder contains XAML ResourceDictionaries extracted from the UI/UX spec to bootstrap the WPF implementation.

Files:
- Colors.xaml — Light/Dark color tokens and brushes (Blue/White/Black palette)
- Typography.xaml — Font families and basic text styles

How to use in WPF:
1. Add the dictionaries to App.xaml:
   
   <Application.Resources>
     <ResourceDictionary>
       <ResourceDictionary.MergedDictionaries>
         <ResourceDictionary Source="/Docs/UI/Resources/Colors.xaml" />
         <ResourceDictionary Source="/Docs/UI/Resources/Typography.xaml" />
       </ResourceDictionary.MergedDictionaries>
     </ResourceDictionary>
   </Application.Resources>

2. Bind styles in XAML:
   <TextBlock Style="{StaticResource Text.H1}" Text="OptiGemini" />

3. Theme switching (light/dark):
   - Option A: Provide separate dictionaries for dark values and swap at runtime
   - Option B: Use DynamicResource and update Brush keys to point to light vs dark values

Notes:
- Keep tokens as the single source of truth. Components should consume brushes/styles, not hardcoded colors/sizes.
- Align chart colors in LiveCharts2 with these tokens.