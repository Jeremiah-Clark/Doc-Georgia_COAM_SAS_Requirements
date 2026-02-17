-- gfm-to-latex.lua
-- Bridges GitHub-Flavored Markdown features to LaTeX for PDF generation.
--
-- IMPORTANT: build.sh must use --from gfm-alerts (not --from gfm) so that
-- Pandoc does NOT natively parse GFM alerts. This keeps them as BlockQuotes,
-- allowing this filter to convert them into our custom LaTeX environments.
--
-- Handles:
--   1. GFM admonitions (> [!WARNING], > [!TIP], etc.) → LaTeX mdframed environments
--   2. Full-width images
--   3. Page breaks before level-1 headings

-- ---------------------------------------------------------------------------
-- 1. GFM Admonitions → LaTeX callout environments
-- ---------------------------------------------------------------------------
-- Supported types (case-insensitive matching, mapped to lowercase env names):

local admonition_map = {
  WARNING   = "warning",
  NOTE      = "note",
  TIP       = "tip",
  IMPORTANT = "important",
  CAUTION   = "caution",
  SUMMARY   = "summary",
  EXAMPLE   = "example",
}

function BlockQuote(el)
  if #el.content == 0 then return el end

  local first_block = el.content[1]
  if first_block.t ~= "Para" then return el end

  -- Stringify the first paragraph and look for [!TYPE]
  local first_text = pandoc.utils.stringify(first_block)
  local admonition_type = first_text:match("^%[!(%u+)%]")

  if not admonition_type then return el end

  local env_name = admonition_map[admonition_type]
  if not env_name then return el end

  -- Extract optional custom title (any text after [!TYPE] on the marker line)
  local custom_title = first_text:match("^%[!%u+%]%s+(.+)$")

  -- Body content always starts from the second block onward;
  -- the first paragraph is consumed entirely (marker + optional title)
  local new_content = pandoc.List()
  for i = 2, #el.content do
    new_content:insert(el.content[i])
  end

  -- Wrap in LaTeX environment, with optional custom title
  local result = pandoc.List()
  if custom_title and custom_title ~= "" then
    result:insert(pandoc.RawBlock("latex", "\\begin{" .. env_name .. "}[" .. custom_title .. "]"))
  else
    result:insert(pandoc.RawBlock("latex", "\\begin{" .. env_name .. "}"))
  end
  result:extend(new_content)
  result:insert(pandoc.RawBlock("latex", "\\end{" .. env_name .. "}"))

  return result
end

-- ---------------------------------------------------------------------------
-- 2. Full-width images
-- ---------------------------------------------------------------------------
-- Pandoc's default LaTeX image output doesn't constrain width. This ensures
-- every image scales to \textwidth so large images don't overflow the page.

function Image(el)
  -- Only override if no explicit width was set in the Markdown
  if not el.attributes.width and not el.attributes.height then
    el.attributes.width = "100%"
  end
  return el
end

-- ---------------------------------------------------------------------------
-- 3. Page breaks before level-1 headings
-- ---------------------------------------------------------------------------
-- Inserts \newpage before every H1 so each major section starts on a fresh page.

function Header(el)
  if el.level == 1 then
    return {
      pandoc.RawBlock("latex", "\\newpage"),
      el,
    }
  end
  return el
end
