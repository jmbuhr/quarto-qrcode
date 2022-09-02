-- for development:
local p = quarto.utils.dump

---Format string like in bash or python,
---e.g. f('Hello ${one}', {one = 'world'})
---@param s string The string to format
---@param kwargs {[string]: string} A table with key-value replacemen pairs
---@return string
local function f(s, kwargs)
  return (s:gsub('($%b{})', function(w) return kwargs[w:sub(3, -2)] or w end))
end

---Add qrcode js dependencies.
local function addDependencies()
  quarto.doc.addHtmlDependency {
    name = 'qrcodejs',
    version = 'v1.0.0',
    scripts = { './assets/qrcode.js' },
  }
end

---Merge user provided options with defaults
---@param userOptions table
---@return string JSON string to pass to molstar
local function mergeOptions(url, userOptions)
  local defaultOptions = {
    text = url,
    width = 128,
    height = 128,
    colorDark = "#000000",
    colorLight = "#ffffff",
  }
  if userOptions == nil then
    return quarto.json.encode(defaultOptions)
  end

  for k, v in pairs(userOptions) do
    local value = pandoc.utils.stringify(v)
    if value == 'true' then value = true end
    if value == 'false' then value = false end
    defaultOptions[k] = value
  end

  return quarto.json.encode(defaultOptions)
end

---@return string
local function wrapInlineDiv(options)
  return [[
<div id="${id}" class="qrcode"></div>
<script type="text/javascript">
var qrcode = new QRCode("${id}", ]]
    .. options..[[);
</script>
    ]]
end

return {
  ['qrcode'] = function(args, kwargs, _)
    if not quarto.doc.isFormat("html:js") then
      return pandoc.Null()
    end
    addDependencies()
    local url = pandoc.utils.stringify(args[1])
    local id = 'qrcode'
    local maybeId = args[2]
    if maybeId ~= nil then
      id = pandoc.utils.stringify(maybeId)
    end
    local options =mergeOptions(url, kwargs)
    local text = wrapInlineDiv(options)
    return pandoc.RawBlock(
      'html',
      f(text, {id=id})
    )
  end,
}

