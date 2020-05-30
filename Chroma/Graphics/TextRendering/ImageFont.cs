﻿using System.Collections.Generic;
using System.IO;
using System.Numerics;
using Chroma.Diagnostics.Logging;
using Chroma.MemoryManagement;
using Chroma.Natives.SDL;

namespace Chroma.Graphics.TextRendering
{
    public class ImageFont : DisposableResource
    {
        private Log Log => LogManager.GetForCurrentAssembly();

        internal Dictionary<char, SDL_gpu.GPU_Rect> GlyphRectangles { get; }

        public Texture Texture { get; }

        public int Height => Texture.Height;

        public int CharSpacing { get; set; } = 2;
        public int LineMargin { get; set; } = 2;

        public ImageFont(string filePath, string alphabet)
        {
            if (!File.Exists(filePath))
                throw new FileNotFoundException("Image font file could not be found.");

            GlyphRectangles = new Dictionary<char, SDL_gpu.GPU_Rect>();
            Texture = new Texture(filePath);

            var separatorColor = Texture[0, 0];

            var x = 0;
            var nextStartingX = 1;

            foreach (var c in alphabet)
            {
                while (Texture[++x, 0] != separatorColor)
                {
                    if (x + 1 > Texture.Width)
                    {
                        Log.Warning($"Character '{c}' is out of bounds for image font.");
                        break;
                    }
                }

                var rect = new SDL_gpu.GPU_Rect
                {
                    x = nextStartingX,
                    y = 0,
                    w = x - nextStartingX,
                    h = Texture.Height
                };
                GlyphRectangles.Add(c, rect);

                nextStartingX = x + 1;
            }
        }

        public Vector2 Measure(string str)
        {
            var vec = new Vector2(0, Height);

            for (var i = 0; i < str.Length; i++)
            {
                var c = str[i];
                
                if (c == '\n')
                {
                    vec.Y += Height + LineMargin;
                    vec.X = 0;
                    
                    continue;
                }

                if (!HasGlyph(c))
                    continue;

                vec.X += GlyphRectangles[c].w;

                if (i + 1 < str.Length)
                    vec.X += CharSpacing;
            }

            return vec;
        }

        public bool HasGlyph(char c)
            => GlyphRectangles.ContainsKey(c);

        protected override void FreeManagedResources()
            => Texture.Dispose();
    }
}