using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace ChromeEvo.Utils
{
    public class CommonUtils
    {
        public static int LayerMaskToLayer(LayerMask _layer)
        {
            int layerNum = 0;
            int layer = _layer.value;
            while(layer > 0)
            {
                layer = layer >> 1;
                layerNum++;
            }

            return layerNum - 1;
        }
    }
}