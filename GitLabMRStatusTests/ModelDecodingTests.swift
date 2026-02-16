import XCTest
@testable import GitLabMRStatus

final class ModelDecodingTests: XCTestCase {

    func testMergeRequestDecoding() throws {
        let json = """
        {
            "id": 1,
            "iid": 42,
            "project_id": 100,
            "title": "Fix login bug",
            "description": "Fixes the login timeout issue",
            "state": "opened",
            "detailed_merge_status": "ci_still_running",
            "draft": false,
            "web_url": "https://gitlab.com/group/project/-/merge_requests/42",
            "source_branch": "fix/login-bug",
            "target_branch": "main",
            "author": {
                "id": 10,
                "name": "John Doe",
                "username": "johndoe",
                "avatar_url": null,
                "web_url": "https://gitlab.com/johndoe"
            },
            "assignees": [],
            "reviewers": [],
            "has_conflicts": false,
            "user_notes_count": 3,
            "upvotes": 1,
            "downvotes": 0,
            "labels": ["bug", "urgent"],
            "merge_when_pipeline_succeeds": false,
            "head_pipeline": {
                "id": 500,
                "status": "running",
                "web_url": "https://gitlab.com/group/project/-/pipelines/500"
            }
        }
        """

        let data = Data(json.utf8)
        let mr = try JSONDecoder().decode(MergeRequest.self, from: data)

        XCTAssertEqual(mr.id, 1)
        XCTAssertEqual(mr.iid, 42)
        XCTAssertEqual(mr.projectId, 100)
        XCTAssertEqual(mr.title, "Fix login bug")
        XCTAssertEqual(mr.state, .opened)
        XCTAssertEqual(mr.detailedMergeStatus, .ciStillRunning)
        XCTAssertEqual(mr.draft, false)
        XCTAssertEqual(mr.sourceBranch, "fix/login-bug")
        XCTAssertEqual(mr.headPipeline?.status, .running)
        XCTAssertEqual(mr.labels, ["bug", "urgent"])
    }

    func testUnknownPipelineStatusDecoding() throws {
        let json = """
        {"id": 1, "status": "some_future_status", "web_url": null}
        """
        let data = Data(json.utf8)
        let pipeline = try JSONDecoder().decode(PipelineInfo.self, from: data)
        XCTAssertEqual(pipeline.status, .unknown)
    }

    func testUnknownDetailedMergeStatusDecoding() throws {
        let json = """
        {
            "id": 1, "iid": 1, "project_id": 1, "title": "test",
            "state": "opened", "detailed_merge_status": "future_status",
            "draft": false, "web_url": "https://example.com",
            "source_branch": "a", "target_branch": "b",
            "author": {"id": 1, "name": "test", "username": "test"},
            "user_notes_count": 0, "upvotes": 0, "downvotes": 0,
            "labels": [], "merge_when_pipeline_succeeds": false
        }
        """
        let data = Data(json.utf8)
        let mr = try JSONDecoder().decode(MergeRequest.self, from: data)
        XCTAssertEqual(mr.detailedMergeStatus, .unknown)
    }

    func testApprovalStateDecoding() throws {
        let json = """
        {
            "approval_rules_overwritten": false,
            "rules": [
                {
                    "id": 1,
                    "name": "Default",
                    "approvals_required": 2,
                    "approved": false,
                    "approved_by": [
                        {
                            "id": 10,
                            "name": "Jane",
                            "username": "jane",
                            "avatar_url": null
                        }
                    ]
                }
            ]
        }
        """
        let data = Data(json.utf8)
        let state = try JSONDecoder().decode(ApprovalStateResponse.self, from: data)

        XCTAssertEqual(state.rules.count, 1)
        XCTAssertEqual(state.rules[0].approvalsRequired, 2)
        XCTAssertEqual(state.rules[0].approved, false)
        XCTAssertEqual(state.rules[0].approvedBy.count, 1)
        XCTAssertEqual(state.rules[0].approvedBy[0].username, "jane")
    }
}
