local M = {}

M.user_vars = {
  kind = 'CODEX_TAB_KIND',
  project = 'CODEX_TAB_PROJECT',
  status = 'CODEX_TAB_STATUS',
  turn_id = 'CODEX_TAB_TURN_ID',
}

local STATUS_STYLES = {
  running = { name = 'running', icon = '●', color = '#e5c07b' },
  done = { name = 'done', icon = '●', color = '#98c379' },
  error = { name = 'error', icon = '●', color = '#e06c75' },
}

local function basename(path)
  if not path or path == '' then
    return ''
  end

  return path:gsub('^.*[\\/]', '')
end

local function is_codex_process(pane)
  if not pane then
    return false
  end

  local name = basename(pane.foreground_process_name):lower()
  return name:find('codex', 1, true) ~= nil
end

local function has_status_prefix(pane)
  local title = pane and pane.title or ''
  if title == '' then
    return false
  end

  local prefix = title:match('^(%S+)%s+.+$')
  return prefix ~= nil and not prefix:match('[%w]')
end

function M.is_codex_pane(pane)
  if not pane then
    return false
  end

  local vars = pane.user_vars or {}
  return vars[M.user_vars.kind] == 'codex' or is_codex_process(pane)
end

function M.status_for_pane(pane)
  if not M.is_codex_pane(pane) then
    return nil
  end

  local vars = pane.user_vars or {}
  local explicit_status = STATUS_STYLES[vars[M.user_vars.status]]
  if explicit_status then
    return explicit_status
  end

  if has_status_prefix(pane) then
    return STATUS_STYLES.running
  end

  return nil
end

return M
