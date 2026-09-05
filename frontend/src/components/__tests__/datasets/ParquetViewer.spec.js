import { describe, it, expect, vi, beforeEach } from "vitest";
import { mount, flushPromises } from "@vue/test-utils";
import ParquetViewer from "../../datasets/ParquetViewer.vue";

// Mock vue-i18n
vi.mock('vue-i18n', () => ({
  useI18n: () => ({
    t: (key) => key,
  })
}));

const mockRowsData = {
  columns: ["id", "text", "label"],
  columns_type: ["int", "string", "string"],
  rows: [
    [1, "First example text", "positive"],
    [2, "Second example text", "negative"]
  ],
  total: 10
};

let getApiMockFn = vi.fn().mockImplementation(() => 
  Promise.resolve({
    data: { value: { data: mockRowsData } },
    error: { value: null }
  })
);

vi.mock('../../../packs/useFetchApi', () => ({
  default: () => ({
    json: getApiMockFn
  })
}));

const datasetInfo = [
  {
    config_name: "default",
    splits: [
      { name: "train", num_examples: 100 },
      { name: "test", num_examples: 20 }
    ]
  },
  {
    config_name: "other_subset",
    splits: [
      { name: "train", num_examples: 50 }
    ]
  }
];

describe("ParquetViewer", () => {
  let wrapper;

  beforeEach(() => {
    getApiMockFn.mockClear();
    wrapper = mount(ParquetViewer, {
      props: {
        datasetInfo,
        namespacePath: "test-namespace/test-dataset"
      }
    });
  });

  it("mounts correctly", () => {
    expect(wrapper.exists()).toBe(true);
  });

  it("loads rows on mount", () => {
    expect(getApiMockFn).toHaveBeenCalled();
  });

  it("calculates splits and subsets computed properties", () => {
    expect(wrapper.vm.numSubsets).toBe(2);
    expect(wrapper.vm.numSplits).toBe(2);
  });

  it("processes table data correctly", async () => {
    await flushPromises();
    expect(wrapper.vm.tableData).toEqual([
      { id: "1", text: "First example text", label: "positive" },
      { id: "2", text: "Second example text", label: "negative" }
    ]);
  });

  it("updates subset and split variables on dropdown changes", async () => {
    await flushPromises();
    // Change subset
    await wrapper.vm.changeSubsetName("other_subset");
    await flushPromises();
    expect(wrapper.vm.subset).toBe("other_subset");
    expect(wrapper.vm.split).toBe("train");
    expect(wrapper.vm.numSplits).toBe(1);

    // Change split
    await wrapper.vm.changeSplitName("train");
    await flushPromises();
    expect(wrapper.vm.split).toBe("train");
  });

  it("renders column headers with formatted column type badges", async () => {
    await flushPromises();
    const headerText = wrapper.find('.el-table__header-wrapper').text();
    expect(headerText).toContain("id");
    expect(headerText).toContain("int");
    expect(headerText).toContain("text");
    expect(headerText).toContain("str");
    expect(headerText).toContain("label");
  });

  it("sorts numeric columns numerically instead of lexicographically", () => {
    const sortFn = wrapper.vm.getSortMethod("id", 0);
    expect(sortFn({ id: "2" }, { id: "10" })).toBeLessThan(0);
    expect(sortFn({ id: "10" }, { id: "2" })).toBeGreaterThan(0);
    expect(sortFn({ id: "2" }, { id: "2" })).toBe(0);
  });
});
