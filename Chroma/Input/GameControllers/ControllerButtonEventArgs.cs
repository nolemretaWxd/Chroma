﻿namespace Chroma.Input.GameControllers
{
    public class ControllerButtonEventArgs
    {
        public ControllerDriver Controller { get; }
        public ControllerButton Button { get; }

        internal ControllerButtonEventArgs(ControllerDriver controller, ControllerButton button)
        {
            Controller = controller;
            Button = button;
        }
    }
}