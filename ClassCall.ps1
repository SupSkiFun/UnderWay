# Run from shell to test overloading.
$Source = @"
using System;
namespace Fun
{
    public static class Area
    {
        public static double computeArea(double width)
        {
            double radius = width / 2;
            return Math.Round(((radius * radius) * 3.141593),2);
        }
        public static double computeArea(double width, double height)
        {
            return (width * height);
        }
        public static double computeArea(double width, double height, char letter)
        {
            return ((width / 2) * height);
        }
    }
}
"@

Add-Type -TypeDefinition $Source -Language CSharp