#include "src/state_storage.h"

#include <boost/property_tree/json_parser.hpp>
#include <boost/property_tree/ptree.hpp>
#include <gtest/gtest.h>

#include <chrono>
#include <filesystem>
#include <fstream>
#include <string>

namespace {
  namespace fs = std::filesystem;
  namespace pt = boost::property_tree;

  fs::path unique_state_path(const std::string &label) {
    const auto stamp = std::chrono::steady_clock::now().time_since_epoch().count();
    return fs::temp_directory_path() / (label + "-" + std::to_string(stamp) + ".json");
  }

  void cleanup_state_family(const fs::path &path) {
    std::error_code ec;
    fs::remove(path, ec);
    fs::remove(fs::path(path.string() + ".bak"), ec);
    const auto prefix = path.filename().string() + ".corrupt.";
    for (const auto &entry : fs::directory_iterator(path.parent_path(), ec)) {
      if (ec) {
        break;
      }
      if (entry.path().filename().string().rfind(prefix, 0) == 0) {
        fs::remove(entry.path(), ec);
      }
    }
  }
}  // namespace

TEST(StateStorageRecovery, RestoresNewestBackupWhenPrimaryJsonIsMalformed) {
  const auto path = unique_state_path("nimbus-state-recovery");
  cleanup_state_family(path);

  pt::ptree initial;
  initial.put("root.version", "old");
  statefile::write_json_atomic(path.string(), initial);

  pt::ptree latest;
  latest.put("root.version", "latest");
  latest.put("root.session_tokens.token", "keep-me");
  statefile::write_json_atomic(path.string(), latest);
  ASSERT_TRUE(fs::exists(path.string() + ".bak"));

  {
    std::ofstream out(path, std::ios::binary | std::ios::trunc);
    out << "{ malformed";
  }

  pt::ptree recovered;
  EXPECT_TRUE(statefile::read_json_with_recovery(path.string(), recovered));
  EXPECT_EQ("latest", recovered.get<std::string>("root.version"));
  EXPECT_EQ("keep-me", recovered.get<std::string>("root.session_tokens.token"));

  pt::ptree restored_primary;
  pt::read_json(path.string(), restored_primary);
  EXPECT_EQ("latest", restored_primary.get<std::string>("root.version"));

  bool corrupt_preserved = false;
  const auto prefix = path.filename().string() + ".corrupt.";
  std::error_code ec;
  for (const auto &entry : fs::directory_iterator(path.parent_path(), ec)) {
    if (ec) {
      break;
    }
    if (entry.path().filename().string().rfind(prefix, 0) == 0) {
      corrupt_preserved = true;
      break;
    }
  }
  EXPECT_TRUE(corrupt_preserved);

  cleanup_state_family(path);
}
