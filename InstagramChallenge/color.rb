module Color

    def rgb_to_xyz
      red, green, blue = @rgb

      red, green, blue = red/255.to_f, green/255.to_f, blue/255.to_f

      color = lambda do |c|
        c > 0.04045 ? c = ((c + 0.055)/1.055) ** 2.4 : c /= 12.92
      end

      red, green, blue = color.call(red), color.call(green), color.call(blue)

      red *= 100
      green *= 100
      blue *= 100

      x = (red * 0.4124) + (green * 0.3576) + (blue * 0.1805)
      y = (red * 0.2126) + (green * 0.7152) + (blue * 0.0722)
      z = (red * 0.0193) + (green * 0.1192) + (blue * 0.9505)

      [x, y, z]
    end

    def xyz_to_lab
      x, y, z = rgb_to_xyz

      x, y, z = x / 95.047.to_f, y / 100.to_f, z / 108.883.to_f

      color = lambda do |c|
        c > 0.008856 ? c = c ** (1/3.to_f) : c = (c * 7.787) + (16/116.to_f)
      end

      x, y, z = color.call(x), color.call(y), color.call(z)

      l, a, b = (116 * y) - 16, 500 * (x - y), 200 * (y - z)

      [l, a, b]
    end



    def self.delta_e_94(p1, p2)
      l1, a1, b1, l2, a2, b2 = p1.lab[0], p1.lab[1], p1.lab[2], p2.lab[0], p2.lab[1], p2.lab[2]

      c1, c2 = Math.sqrt((a1 * a1) + (b1 * b1)), Math.sqrt((a2 * a2) + (b2 * b2))

      dc = c1 -c2

      d1, da, db = l1 - l2, a1 - a2, b1 -b2

      if ((da * da) + (db * db) - (dc * dc)) < 0
        dh = 0
      else
        dh = Math.sqrt((da * da) + (db * db) - (dc * dc))
      end

      first, second, third = d1, dc / (1 + (0.045 * c1)), dh / (1 + (0.015 * c1))
        
      Math.sqrt((first * first) + (second * second) + (third * third))
    end


end
