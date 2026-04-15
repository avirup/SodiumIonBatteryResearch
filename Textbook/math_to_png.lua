local root_dir = os.getenv("KINDLE_BUILD_ROOT") or "."
local math_dir = root_dir .. "/kindle/math"

local function ensure_dir(path)
  os.execute('mkdir -p "' .. path .. '"')
end

local function file_exists(path)
  local f = io.open(path, "rb")
  if f then
    f:close()
    return true
  end
  return false
end

local function write_file(path, content)
  local f = assert(io.open(path, "w"))
  f:write(content)
  f:close()
end

local function render_math(el)
  ensure_dir(math_dir)

  local mode = (el.mathtype == "DisplayMath") and "display" or "inline"
  local key = pandoc.sha1(mode .. "\n" .. el.text)
  local base = math_dir .. "/" .. mode .. "-" .. key
  local tex_path = base .. ".tex"
  local dvi_path = base .. ".dvi"
  local svg_path = base .. ".svg"
  local png_path = base .. ".png"
  local rel_png_path = "kindle/math/" .. mode .. "-" .. key .. ".png"

  if not file_exists(png_path) then
    local tex = table.concat({
      "\\documentclass[preview]{standalone}",
      "\\usepackage{amsmath,amssymb,amsfonts}",
      "\\begin{document}",
      mode == "display" and "\\[" .. el.text .. "\\]" or "$" .. el.text .. "$",
      "\\end{document}",
      ""
    }, "\n")

    write_file(tex_path, tex)

    pandoc.pipe(
      "latex",
      {"-interaction=nonstopmode", "-halt-on-error", "-output-directory=" .. math_dir, tex_path},
      ""
    )

    pandoc.pipe(
      "dvisvgm",
      {"--no-fonts", "--exact", dvi_path, "-o", svg_path},
      ""
    )

    pandoc.pipe(
      "convert",
      {
        "-background", "white",
        "-density", "220",
        svg_path,
        "-colorspace", "Gray",
        "-trim", "+repage",
        png_path
      },
      ""
    )
  end

  local image = pandoc.Image(
    {pandoc.Str(el.text)},
    rel_png_path,
    "",
    pandoc.Attr("", {"math-" .. mode}, {})
  )
  return image
end

function Math(el)
  return render_math(el)
end
